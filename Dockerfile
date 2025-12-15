FROM archlinux:base-devel

# Install paru from archlinuxcn
# Then remove the archlinuxcn repo to make sure the package builds without it
RUN printf '[multilib]\nInclude = /etc/pacman.d/mirrorlist\n[archlinuxcn]\nServer = https://mirrors.xtom.us/archlinuxcn/$arch' >> /etc/pacman.conf \
    && pacman --noconfirm -Syyu \
    && pacman-key --init \
    && pacman --noconfirm -S archlinuxcn-keyring \
    && pacman --noconfirm -S paru \
    && pacman -Rns --noconfirm archlinuxcn-keyring \
    && sed -i '/archlinuxcn/d' /etc/pacman.conf

# Add non-root build user
RUN useradd -m build && echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/build
USER build

# Set NoCheck
RUN mkdir -p .config/paru
COPY paru.conf .config/paru

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
