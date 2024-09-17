FROM archlinux:base-devel

RUN printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
RUN pacman -Syu --needed --noconfirm git

RUN useradd -m build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/build
USER build

RUN git clone https://aur.archlinux.org/paru-git.git
RUN cd paru-git && makepkg -si --noconfirm

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
