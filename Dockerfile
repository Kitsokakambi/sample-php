# Stage 1: Build stage
FROM php:8.1-cli AS build

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y libzip-dev git unzip && \
    docker-php-ext-install zip

# Set the working directory
WORKDIR /app

# Copy composer.json and install PHP dependencies
COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --prefer-dist

# Copy the application files
COPY . .

# Stage 2: Production stage
FROM php:8.1-apache

# Set the working directory
WORKDIR /var/www/html

# Copy the build stage application files
COPY --from=build /app /var/www/html

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Expose the necessary port (usually 80 for Apache)
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
