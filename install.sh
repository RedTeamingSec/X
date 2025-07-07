#!/bin/bash

# Fungsi untuk menampilkan pesan error dan keluar
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Menginstal Dependensi yang Diperlukan
echo "Menginstal dependensi..."
sudo apt-get install -y autoconf automake pkg-config make gcc || error_exit "Gagal menginstal dependensi"

# Unduh Paket libpam dari GitHub
echo "Mengunduh libpam..."
git clone https://github.com/linux-pam/linux-pam.git || error_exit "Gagal mengunduh libpam"

# Masuk ke direktori libpam
cd linux-pam || error_exit "Gagal masuk ke direktori libpam"

# Menjalankan autogen.sh untuk menghasilkan file configure
echo "Menjalankan autogen.sh..."
./autogen.sh || error_exit "Gagal menjalankan autogen.sh"

# Mengonfigurasi libpam
echo "Mengonfigurasi libpam..."
./configure --prefix=/usr --sysconfdir=/etc || error_exit "Gagal mengonfigurasi libpam"

# Mengompilasi libpam
echo "Mengompilasi libpam..."
make || error_exit "Gagal mengompilasi libpam"

# Menginstal libpam
echo "Menginstal libpam..."
sudo make install || error_exit "Gagal menginstal libpam"

# Verifikasi Instalasi
echo "Verifikasi instalasi libpam..."
ls /usr/lib | grep pam || error_exit "libpam tidak ditemukan di /usr/lib"
ls /usr/include/security | grep pam || error_exit "Header libpam tidak ditemukan di /usr/include/security"

# Cek versi libpam menggunakan pkg-config (jika tersedia)
pkg-config --modversion pam || error_exit "libpam tidak ditemukan dengan pkg-config"

echo "Instalasi libpam-devel berhasil!"
