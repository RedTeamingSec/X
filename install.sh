#!/bin/bash

# Fungsi untuk menampilkan pesan error dan keluar
function error_exit {
    echo "$1" 1>&2
    exit 1
}

# Menginstal kbd
echo "Menginstal kbd..."
# Unduh paket kbd
wget https://www.kernel.org/pub/linux/utils/kbd/kbd-2.5.0.tar.xz || error_exit "Gagal mengunduh kbd"

# Ekstrak paket
tar -xvf kbd-2.5.0.tar.xz || error_exit "Gagal mengekstrak kbd"

# Masuk ke direktori kbd
cd kbd-2.5.0 || error_exit "Gagal masuk ke direktori kbd"

# Mengonfigurasi dan menginstal kbd
./configure --prefix=/usr || error_exit "Gagal mengonfigurasi kbd"
make || error_exit "Gagal mengompilasi kbd"
sudo make install || error_exit "Gagal menginstal kbd"

# Kembali ke direktori sumber
cd ..

# Menginstal libpam
echo "Menginstal libpam..."

# Unduh libpam dari GitHub
git clone https://github.com/linux-pam/linux-pam.git || error_exit "Gagal mengunduh libpam"

# Masuk ke direktori libpam
cd linux-pam || error_exit "Gagal masuk ke direktori libpam"

# Mengonfigurasi dan menginstal libpam
./autogen.sh || error_exit "Gagal menjalankan autogen.sh"
./configure --prefix=/usr --sysconfdir=/etc || error_exit "Gagal mengonfigurasi libpam"
make || error_exit "Gagal mengompilasi libpam"
sudo make install || error_exit "Gagal menginstal libpam"

# Kembali ke direktori sumber
cd ..

# Verifikasi instalasi
echo "Verifikasi instalasi kbd dan libpam..."

# Cek apakah kbd terinstal
which setfont > /dev/null || error_exit "setfont tidak ditemukan, instalasi kbd gagal"

# Cek apakah libpam terinstal
pkg-config --modversion pam > /dev/null || error_exit "libpam tidak ditemukan, instalasi libpam gagal"

echo "Instalasi kbd dan libpam berhasil!"
