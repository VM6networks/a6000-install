#!/bin/bash

# RTX A6000 Driver Installation Script
# This script detects your Linux distribution and installs appropriate NVIDIA drivers
# from the distribution's official repositories

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_info "Starting RTX A6000 driver installation..."
echo ""

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    VERSION=$VERSION_ID
    print_info "Detected OS: $NAME $VERSION"
else
    print_error "Cannot detect Linux distribution"
    exit 1
fi

# Function to install drivers based on distribution
install_drivers() {
    case $DISTRO in
        ubuntu|debian|linuxmint|pop)
            print_info "Installing NVIDIA drivers for Debian-based system..."
            apt-get update
            apt-get install -y nvidia-driver-545 nvidia-utils-545 nvidia-cuda-toolkit
            print_success "Driver installation completed"
            ;;
            
        fedora)
            print_info "Installing NVIDIA drivers for Fedora..."
            dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
            print_success "Driver installation completed"
            ;;
            
        rhel|centos|rocky|almalinux)
            print_info "Installing NVIDIA drivers for RHEL-based system..."
            # Enable EPEL repository
            dnf install -y epel-release
            # Enable PowerTools/CRB repository
            if [[ "$VERSION" == "8"* ]]; then
                dnf config-manager --set-enabled powertools
            elif [[ "$VERSION" == "9"* ]]; then
                dnf config-manager --set-enabled crb
            fi
            dnf install -y kmod-nvidia nvidia-driver-cuda
            print_success "Driver installation completed"
            ;;
            
        arch|manjaro)
            print_info "Installing NVIDIA drivers for Arch-based system..."
            pacman -Syu --noconfirm nvidia nvidia-utils cuda
            print_success "Driver installation completed"
            ;;
            
        opensuse*|sles)
            print_info "Installing NVIDIA drivers for openSUSE..."
            zypper install -y nvidia-computeG06 nvidia-glG06
            print_success "Driver installation completed"
            ;;
            
        gentoo)
            print_info "Installing NVIDIA drivers for Gentoo..."
            emerge --ask=n x11-drivers/nvidia-drivers
            print_success "Driver installation completed"
            ;;
            
        *)
            print_error "Unsupported distribution: $DISTRO"
            print_info "Please install NVIDIA drivers manually from your distribution's repository"
            exit 1
            ;;
    esac
}

# Install drivers
install_drivers

# Load NVIDIA kernel module
print_info "Loading NVIDIA kernel module..."
if modprobe nvidia 2>/dev/null; then
    print_success "NVIDIA module loaded successfully"
else
    print_warning "Could not load NVIDIA module. A reboot may be required."
fi

# Verify installation
print_info "Verifying installation..."
if command -v nvidia-smi &> /dev/null; then
    echo ""
    print_success "NVIDIA driver installed successfully!"
    echo ""
    nvidia-smi
    echo ""
else
    print_warning "nvidia-smi command not found. Installation may require a reboot."
fi

# Final message
echo ""
echo "════════════════════════════════════════════════════════════════"
print_success "RTX A6000 Driver Installation Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
print_info "Next steps:"
echo "  1. Reboot your system to ensure all drivers are loaded correctly"
echo "  2. After reboot, run 'nvidia-smi' to verify your RTX A6000 is detected"
echo "  3. Check driver version with 'nvidia-smi --query-gpu=driver_version --format=csv'"
echo ""
print_success "Thank you for using VM6 Networks Hosting services!"
echo "════════════════════════════════════════════════════════════════"
echo ""