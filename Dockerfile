FROM archlinux

RUN pacman -Syu --needed --noconfirm git namcap base-devel

RUN printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

RUN useradd -m build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/build
USER build

RUN git clone https://aur.archlinux.org/paru-bin.git
RUN cd paru-bin && makepkg -si --noconfirm

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
