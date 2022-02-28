#! /bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
echo '<html><head><title>Whisky Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">Have a &#129347 with grandpa</span></span></p></body></html>' | sudo tee /var/www/html/index.nginx-debian.html
