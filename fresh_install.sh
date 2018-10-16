apt install vim xorg lightdm rofi i3 rxvt-unicode compton fonts-roboto arc-theme lxappearance feh fonts-font-awesome git

mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

git clone https://github.com/vim-airline/vim-airline ~/.vim/bundle/vim-airline
git clone https://github.com/Xuyuanp/nerdtree-git-plugin.git ~/.vim/bundle/nerdtree-git-plugin

