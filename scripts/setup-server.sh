#!/bin/bash

# Script untuk setup server Prima.id deployment
# Jalankan script ini di server sebagai root atau user dengan sudo

set -e

echo "🚀 Setting up Prima.id deployment server..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   print_error "Script ini harus dijalankan sebagai root atau dengan sudo"
   exit 1
fi

# Get deployment user
DEPLOY_USER=${1:-prima}
print_status "Setting up deployment user: $DEPLOY_USER"

# Create deployment user if not exists
if ! id "$DEPLOY_USER" &>/dev/null; then
    print_status "Creating user $DEPLOY_USER..."
    adduser --disabled-password --gecos "" $DEPLOY_USER
    usermod -aG sudo $DEPLOY_USER
else
    print_status "User $DEPLOY_USER already exists"
fi

# Create deployment directories
print_status "Creating deployment directories..."
mkdir -p /var/www/prima-v2/api
mkdir -p /var/www/prima-v2/web
mkdir -p /var/www/prima-staging-v2/api
mkdir -p /var/www/prima-staging-v2/web

# Set ownership and permissions
chown -R $DEPLOY_USER:$DEPLOY_USER /var/www/prima-v2/
chown -R $DEPLOY_USER:$DEPLOY_USER /var/www/prima-staging-v2/
chmod -R 755 /var/www/prima-v2/
chmod -R 755 /var/www/prima-staging-v2/

# Setup NOPASSWD sudo for nginx commands
print_status "Setting up NOPASSWD sudo for nginx commands..."
if ! grep -q "$DEPLOY_USER.*systemctl.*nginx" /etc/sudoers; then
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl reload nginx" >> /etc/sudoers
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart nginx" >> /etc/sudoers
    echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl status nginx" >> /etc/sudoers
    print_status "NOPASSWD sudo rules added"
else
    print_status "NOPASSWD sudo rules already exist"
fi

# Create deployment scripts directory
print_status "Creating deployment scripts directory..."
mkdir -p /home/$DEPLOY_USER/deploy-scripts
chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/deploy-scripts

# Create nginx reload script
cat > /home/$DEPLOY_USER/deploy-scripts/reload-nginx.sh << 'EOF'
#!/bin/bash
echo "Reloading nginx configuration..."
sudo systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Failed to reload nginx"
    exit 1
fi
EOF

chmod +x /home/$DEPLOY_USER/deploy-scripts/reload-nginx.sh
chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/deploy-scripts/reload-nginx.sh

# Install Node.js and npm if not installed
if ! command -v node &> /dev/null; then
    print_status "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
else
    print_status "Node.js already installed"
fi

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    print_status "Installing PM2..."
    npm install -g pm2
else
    print_status "PM2 already installed"
fi

# Setup PM2 startup
print_status "Setting up PM2 startup..."
sudo -u $DEPLOY_USER pm2 startup

print_status "✅ Server setup completed successfully!"
print_status ""
print_status "Next steps:"
print_status "1. Generate SSH key pair for deployment user:"
print_status "   ssh-keygen -t rsa -b 4096 -C 'prima@deployment' -f /home/$DEPLOY_USER/.ssh/id_rsa"
print_status ""
print_status "2. Add public key to GitHub Secrets as SSH_PRIVATE_KEY:"
print_status "   cat /home/$DEPLOY_USER/.ssh/id_rsa"
print_status ""
print_status "3. Set SSH_USER secret in GitHub to: $DEPLOY_USER"
print_status ""
print_status "4. Configure Nginx virtual hosts for your domains"
print_status ""
print_status "5. Test deployment by pushing to main or develop branch" 