#!/bin/bash

# Fungsi untuk menampilkan pesan error dan keluar
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Menginstal Dependensi yang Dibutuhkan
echo "Menginstal dependensi yang dibutuhkan..."
sudo apt-get install -y autoconf automake pkg-config make gcc wget || error_exit "Gagal menginstal dependensi."

# Menginstal kbd
echo "Menginstal kbd..."
# Unduh paket kbd
wget https://www.kernel.org/pub/linux/utils/kbd/kbd-2.5.0.tar.xz || error_exit "Gagal mengunduh kbd."

# Ekstrak file kbd
tar -xvf kbd-2.5.0.tar.xz || error_exit "Gagal mengekstrak kbd."

# Masuk ke direktori kbd
cd kbd-2.5.0 || error_exit "Gagal masuk ke direktori kbd."

# Mengonfigurasi dan menginstal kbd
./configure --prefix=/usr || error_exit "Gagal mengonfigurasi kbd."
make || error_exit "Gagal mengompilasi kbd."
sudo make install || error_exit "Gagal menginstal kbd."

# Kembali ke direktori sumber
cd ..

# Menginstal libpam
LIBPAM_VERSION="1.5.1"
LIBPAM_URL="https://github.com/linux-pam/linux-pam/releases/download/v${LIBPAM_VERSION}/Linux-PAM-${LIBPAM_VERSION}.tar.xz"

echo "Menginstal libpam versi ${LIBPAM_VERSION}..."
# Unduh file tar.xz dari libpam
wget ${LIBPAM_URL} || error_exit "Gagal mengunduh libpam."

# Ekstrak file tar.xz
tar -xvf Linux-PAM-${LIBPAM_VERSION}.tar.xz || error_exit "Gagal mengekstrak libpam."

# Masuk ke direktori libpam
cd Linux-PAM-${LIBPAM_VERSION} || error_exit "Gagal masuk ke direktori libpam."

# Menjalankan autogen.sh untuk menghasilkan configure (jika tidak ada configure)
echo "Menjalankan autogen.sh untuk menghasilkan configure..."
./autogen.sh || error_exit "Gagal menjalankan autogen.sh."

# Mengonfigurasi libpam
echo "Mengonfigurasi libpam..."
./configure --prefix=/usr --sysconfdir=/etc || error_exit "Gagal mengonfigurasi libpam."

# Mengompilasi libpam
echo "Mengompilasi libpam..."
make || error_exit "Gagal mengompilasi libpam."

# Menginstal libpam
echo "Menginstal libpam..."
sudo make install || error_exit "Gagal menginstal libpam."

# Verifikasi Instalasi
echo "Verifikasi instalasi kbd dan libpam..."
ls /usr/lib | grep pam || error_exit "libpam tidak ditemukan di /usr/lib"
ls /usr/include/security | grep pam || error_exit "Header libpam tidak ditemukan di /usr/include/security"
which setfont || error_exit "setfont tidak ditemukan, instalasi kbd gagal."

# Cek versi libpam menggunakan pkg-config (jika tersedia)
pkg-config --modversion pam || error_exit "libpam tidak ditemukan dengan pkg-config."

echo "Instalasi kbd dan libpam-devel berhasil!"
