#!/bin/bash

# Fungsi untuk menampilkan pesan error dan keluar
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Menentukan versi libpam yang akan diunduh
LIBPAM_VERSION="1.5.1"
LIBPAM_URL="https://github.com/linux-pam/linux-pam/releases/download/v${LIBPAM_VERSION}/pam-${LIBPAM_VERSION}.tar.xz"

# Menginstal dependensi yang dibutuhkan
echo "Menginstal dependensi yang dibutuhkan..."

# Unduh file tar.xz dari libpam
echo "Mengunduh libpam versi ${LIBPAM_VERSION}..."
wget ${LIBPAM_URL} || error_exit "Gagal mengunduh libpam."

# Ekstrak file tar.xz
echo "Mengekstrak libpam..."
tar -xvf pam-${LIBPAM_VERSION}.tar.xz || error_exit "Gagal mengekstrak libpam."

# Masuk ke direktori libpam
cd pam-${LIBPAM_VERSION} || error_exit "Gagal masuk ke direktori libpam."

# Menjalankan autogen.sh untuk menghasilkan file configure (jika tidak ada configure)
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
echo "Verifikasi instalasi libpam..."
ls /usr/lib | grep pam || error_exit "libpam tidak ditemukan di /usr/lib"
ls /usr/include/security | grep pam || error_exit "Header libpam tidak ditemukan di /usr/include/security"

# Cek versi libpam menggunakan pkg-config (jika tersedia)
pkg-config --modversion pam || error_exit "libpam tidak ditemukan dengan pkg-config."

echo "Instalasi libpam-devel berhasil!"
