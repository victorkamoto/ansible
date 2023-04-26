FROM archlinux:latest AS base
WORKDIR /usr/local/bin

# Update the mirrorlist file
RUN pacman -Syy --noconfirm && \
    pacman -S reflector --noconfirm && \
    reflector --verbose -l 10 --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel curl git sudo ansible && \
    pacman -Scc --noconfirm

FROM base AS personal
ARG TAGS
RUN useradd -m -G wheel -s /bin/bash vic
RUN echo "vic ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vic
RUN mkdir /home/vic/ansible
WORKDIR /home/vic/ansible
COPY . .
RUN chmod 700 .ssh
RUN chmod 600 .ssh/id_ed25519
RUN chmod 644 .ssh/id_ed25519.pub
RUN chown -R vic:vic .ssh

FROM personal
USER vic
CMD ["ansible-playbook", "$TAGS", "local.yml"]

