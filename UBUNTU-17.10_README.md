### Ubuntu 17.10 installation

This guide will help you setup HackTheArch on a standard Ubuntu 17.10 installation.
Please do note the network listed below (192.168.0.0/16) and modify to suite your needs.

This guide excludes e-mail and chat configuration.

```
sudo apt-get install -y libpq-dev curl vim build-essential git-core sqlite3 libssl-dev libreadline-dev zlib1g-dev libsqlite3-dev nodejs
sudo useradd --create-home --system hta
sudo su - hta

git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone https://github.com/mcpa-stlouis/hack-the-arch.git

cat << "EOF" >> ~/.bashrc
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
export HOST=$HOSTNAME
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
EOF

. ~/.bashrc
rbenv install 2.5.0
rbenv global 2.5.0
cd hack-the-arch/
gem install bundler
gem install rails -v 5.1.4
bundle install
#bundle exec rake db:seed
rails db:migrate
bundle exec rake db:seed
sed -i '$d' config/environments/development.rb
cat << "EOF" >> config/environments/development.rb
  class Application < Rails::Application
    config.web_console.whitelisted_ips = '192.168.0.0/16'
  end
end
EOF

exit

sudo bash -c "cat >> /etc/systemd/system/hta.service" << "EOF"
[Unit]
Description=Hack The Arch
After=network.target

[Service]
Type=simple
User=hta
WorkingDirectory=/home/hta/hack-the-arch/
ExecStart=/home/hta/.rbenv/shims/rails s --binding=0.0.0.0
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

sudo usermod --shell /bin/false hta
sudo systemctl daemon-reload
sudo systemctl start hta
```

HackTheArch should now be browsable on your Ubuntu's system IP:3000
