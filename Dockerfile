FROM ruby:3.1.4-slim

# Installation des dépendances système
RUN apt-get update -qq && \
    apt-get install -y build-essential \
                       libpq-dev \
                       nodejs \
                       default-libmysqlclient-dev \
                       git \
                       curl

# Création du répertoire de l'application
WORKDIR /app

# Installation des gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install

# Copie du code de l'application
COPY . .

# Précompilation des assets
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile RAILS_ENV=production

# Nettoyage
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configuration des permissions
RUN chmod +x /app/bin/* && \
    chmod -R 755 /app/public/assets
