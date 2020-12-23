FROM node:10-buster

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libsecret-1-dev \
    groff \
    less \
    bash-completion \
&& rm -rf /var/lib/apt/lists/*

ENV npm_config_user root

RUN npm install twilio-cli twilio-run create-twilio-function eslint -g
RUN twilio plugins:install @twilio-labs/plugin-serverless
RUN twilio autocomplete bash --refresh-cache && printf "$(twilio autocomplete:script bash)" >> ~/.bashrc

RUN pip3 install virtualenv debugpy

WORKDIR /usr/src/twilio

EXPOSE 5566

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo $SNIPPET >> "/root/.bashrc" \
    # [Optional] If you have a non-root user
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $(whoami) /commandhistory \
    && mkdir -p "/home/$(whoami)" \
    && echo $SNIPPET >> "/home/$(whoami)/.bashrc"
