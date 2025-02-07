FROM ruby:3.1.4-slim

# Installation des dépendances système
RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       libpq-dev \
                       nodejs \
                       default-libmysqlclient-dev \
                       git \
                       curl \
                       chromium \
                       chromium-driver && \
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | apt-key add - && \
    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list && \
    apt-get update && apt-get install -y ngrok && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Création du répertoire de l'application
WORKDIR /app

# Configuration des permissions bundle
RUN mkdir -p /usr/local/bundle && \
    chmod -R 777 /usr/local/bundle

# Copie et installation des gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copie du code de l'application
COPY . .

# Configuration des permissions
RUN chmod +x /app/bin/* && \
    chmod -R 777 /app/tmp /app/log /app/public

# Create start script
COPY <<-"EOF" /app/start.sh
#!/bin/bash
rm -f /app/tmp/pids/server.pid

if [ "$RAILS_ENV" = "production" ]; then
    # En production, on précompile les assets
    SECRET_KEY_BASE=dummy bundle exec rails assets:precompile
fi

# Démarrage du serveur Rails
bundle exec rails server -b 0.0.0.0 -e ${RAILS_ENV:-development} &

# Lancer ngrok pour exposer l'application Rails
ngrok http 3000 --log=stdout
EOF

RUN chmod +x /app/start.sh

# Expose port 3000
EXPOSE 3000

# Démarrage
CMD ["/app/start.sh"]
