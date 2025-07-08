#!/bin/bash

# ======================================================
# SCRIPT INSTALASI XORG DI LINUX FROM SCRATCH (LFS)
# Termasuk link download resmi dan dependencies minimal
# ======================================================

# Pastikan dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
  echo "ERROR: Script harus dijalankan sebagai root!" >&2
  exit 1
fi

# Konfigurasi
XORG_BASE_URL="https://www.x.org/pub/individual"
DOWNLOAD_DIR="/sources/xorg"
INSTALL_DIR="/usr/local/xorg"
LOG_FILE="/var/log/xorg_install.log"

# Daftar package utama (versi terbaru stabil per Juli 2024)
declare -A PKGS=(
  # Xorg Server
  ["xorg-server"]="21.1.11"
  
  # Libraries
  ["libX11"]="1.8.7"
  ["libXext"]="1.3.5"
  ["libXrender"]="0.9.11"
  ["libXft"]="2.3.8"
  
  # Tools
  ["xinit"]="1.4.2"
  ["xauth"]="1.1.2"
  ["xset"]="1.2.5"
  ["xrandr"]="1.5.2"
  
  # Drivers
  ["xf86-input-libinput"]="1.3.0"
  ["xf86-video-fbdev"]="0.5.0"
  
  # Fonts
  ["font-util"]="1.4.1"
  ["xorg-fonts"]="7.7"
)

# Dependencies wajib
DEPS=(
  "mesa"
  "libdrm"
  "libxcb"
  "xtrans"
  "libpciaccess"
  "pixman"
  "freetype"
  "fontconfig"
)

# ===== FUNGSI UTAMA =====
install_deps() {
  echo "[DEPENDENCIES] Memeriksa paket yang diperlukan..."
  for dep in "${DEPS[@]}"; do
    if ! pkg-config --exists $dep; then
      echo "ERROR: $dep belum terinstal!" >&2
      echo "Instal manual dengan:"
      echo "  wget https://www.x.org/pub/individual/<package>/<package-version>.tar.gz"
      echo "  ./configure --prefix=$INSTALL_DIR && make && make install"
      exit 1
    fi
  done
}

download_and_compile() {
  local pkg=$1
  local ver=${PKGS[$pkg]}
  local pkg_file="$pkg-$ver.tar.bz2"
  local pkg_url="$XORG_BASE_URL/${pkg%%-*}/$pkg/$pkg_file"

  echo "[DOWNLOAD] Mengunduh $pkg-$ver..."
  if ! wget -q --show-progress "$pkg_url" -P "$DOWNLOAD_DIR"; then
    echo "ERROR: Gagal mengunduh $pkg!" >&2
    exit 1
  fi

  echo "[COMPILE] Mengekstrak dan mengompilasi $pkg..."
  tar -xf "$DOWNLOAD_DIR/$pkg_file" -C "$DOWNLOAD_DIR" || exit 1
  cd "$DOWNLOAD_DIR/$pkg-$ver" || exit 1
  
  ./configure --prefix="$INSTALL_DIR" >> "$LOG_FILE" 2>&1
  make >> "$LOG_FILE" 2>&1
  make install >> "$LOG_FILE" 2>&1
  
  if [ $? -ne 0 ]; then
    echo "ERROR: Kompilasi $pkg gagal! Lihat log di $LOG_FILE" >&2
    exit 1
  fi
  
  cd ..
  rm -rf "$pkg-$ver"
}

# ===== EKSEKUSI =====
main() {
  # Persiapan direktori
  mkdir -pv "$DOWNLOAD_DIR" "$INSTALL_DIR"
  echo "Log instalasi tersimpan di: $LOG_FILE"
  echo "" > "$LOG_FILE"
  
  # Install dependencies
  install_deps
  
  # Download dan kompilasi semua package
  for pkg in "${!PKGS[@]}"; do
    download_and_compile "$pkg"
  done
  
  # Setup environment
  cat << EOF >> /etc/profile
export PATH="\$PATH:$INSTALL_DIR/bin"
export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:$INSTALL_DIR/lib"
export PKG_CONFIG_PATH="\$PKG_CONFIG_PATH:$INSTALL_DIR/share/pkgconfig"
EOF
  
  echo -e "\nSUKSES! Xorg terinstal di $INSTALL_DIR"
  echo "Jalankan perintah berikut untuk memuat environment:"
  echo "  source /etc/profile"
}

# Jalankan main function
main
