FROM ruby:3.4.7-trixie

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 4 --retry 3

# Copy application code
COPY . ./

# Create non-root user and set ownership
RUN useradd -m -u 1000 worker && chown -R worker:worker /app
USER worker

# Environment variables for Redis configuration
ENV REDIS_HOST=localhost \
    REDIS_PORT=6379

EXPOSE 4567

LABEL maintainer="wrspada02" \
      description="Ruby API to enqueue items"

CMD ["bundle", "exec", "ruby", "app.rb"]
