# Use the official Ruby image as the base image
FROM ruby:3.1.4

# Set the working directory inside the container
WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y nodejs && \
    gem install bundler

# Create and set permissions for bundle directory
RUN mkdir -p /usr/local/bundle && \
    chmod -R 777 /usr/local/bundle

# Copy Gemfile and Gemfile.lock to the working directory
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Set permissions for the app directory
RUN chmod -R 777 /app

# Expose port 3000 to the outside world
EXPOSE 3000

# Create start script
COPY <<-"EOF" /app/start.sh
#!/bin/bash
rm -f /app/tmp/pids/server.pid
rails server -b 0.0.0.0
EOF

RUN chmod +x /app/start.sh

# Start the Rails server using the start script
CMD ["/app/start.sh"]