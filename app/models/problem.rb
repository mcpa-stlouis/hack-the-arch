class Problem < ApplicationRecord
  mount_uploader :picture, PictureUploader
  has_many :hint_requests, dependent: :destroy, inverse_of: :problem
  has_many :submissions, dependent: :destroy, inverse_of: :problem

  belongs_to :parent, :class_name => "Problem", :foreign_key => "parent_problem_id"
  has_many :dependent_problems, :class_name => "Problem", :foreign_key => "parent_problem_id"

  validates :name,  presence: true, length: { maximum: 50 }
  validates :category,  presence: true, length: { maximum: 100 }
  validates :description,  presence: true, length: { maximum: 500 }
  validates :points,  presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :hints, absence: true, on: :create

  # Boolean fields
  validates :visible, inclusion: { in: [true, false] }
  validates :visible, exclusion: { in: [nil] }
  validates :solution_case_sensitive, inclusion: { in: [true, false] }
  validates :solution_case_sensitive, exclusion: { in: [nil] }
  validates :solution_regex, inclusion: { in: [true, false] }
  validates :solution_regex, exclusion: { in: [nil] }
  validate  :picture_size
  validate  :json_format

   def Problem.find_parents(problem)
     unless problem.parent
       return []
     end
     return [problem.parent].concat(find_parents(problem.parent))
   end

  def Problem.find_dependencies(problem)
    if problem.dependent_problems.length <= 0
      return []
    end
    return problem.dependent_problems.concat(problem.dependent_problems.each { |p| find_dependencies(p) } )
  end

  def dependencies_solved_by_team?(team_id)
    deps = Problem.find_dependencies(self)
    if deps.length > 0
      deps.each do |p|
        unless p.solved_by?(team_id)
          return false
        end
      end
    end
    return true
  end

  def solved_by?(team_id)
    self.submissions.where(team: team_id, correct: true).count > 0 ? true : false
  end

  def add(hint_id)
    hint = Hint.find(hint_id)
    save_hints(hints_array.push(hint.id.to_s))
    hint.increment_pointer_counter
  end
  
  def remove(hint_id)
    if self.hints 
      hint = Hint.find(hint_id)
      save_hints(hints_array.reject! { |id| id == hint.id.to_s })
      hint.decrement_pointer_counter
    end
  end

  def remove_all_hints
    if self.hints 
      hint_array = hints_array
      # IMPORTANT: Must save hints before decrementing pointers
      save_hints(hint_array.clear)
      for hint in hint_array
        Hint.find_by(id: hint.to_i).decrement_pointer_counter
      end
    end
  end

  def hints_array
    if !self.hints # Lazy Instantiation
      Array.new
    else
      self.hints.split(',').sort_by{ |id| Hint.find(id).priority }
    end
  end

  def number_of_hints_available
    self.hints_array.count
  end

  def get_next_hint(team_id, problem_id)
    @team = Team.find(team_id)
    num_hints_requested = @team.get_hints_requested(problem_id).count
    hints_array[num_hints_requested]
  end

  protected 
    def json_format
      if self.stack.nil? and self.network.nil?
        return
      end

			unless self.stack.is_json? and self.network.is_json?
				errors[:base] << "Containers or network are not valid json"
			end
    end

  private

    # Don't give access to the array directly 
    def save_hints(hints_array)
      update_attribute(:hints, hints_array.join(','))
    end
  
    # Validates the size of an uploaded picture.
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

end
