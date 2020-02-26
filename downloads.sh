## SOFTWARE: samtools
## VERSION: 1.9
## TYPE: file format converter
## SOURCE_URL: https://github.com/samtools/samtools
wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
tar -xjf samtools-1.9.tar.bz2
cd samtools-1.9
make
cd ..
ln -s samtools-1.9 samtools
