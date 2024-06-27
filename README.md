# apuntes-docker
README todo sobre Docker.

## Ejecutar ejemplo con docker

```bash
# Crear imagen
docker build -t myapp .

# Desplegar contenedor a partir de una imagen con docker en el puerto
# Ejemplo: Puerto entrada: 80 / Puerto salida: 80
docker run -dp 3000:3000 myapp

# Crear un contenedor a partir de una imagen con docker en el puerto
# Ejemplo: Puerto entrada: 80 / Puerto salida: 80
# Incluye un argumento extra --add-host=
# Ejemplo "networkLocalhost:MyIPv4"
docker run -dp 3000:3000 --add-host=networkLocalhost:192.168.0.0 myapp
```

## Ejecutar ejemplo con docker-compose

```bash
# Crear imagen y deplegar contenedor
docker-compose up -d --build
# Detener y eliminar contenedores, redes, volúmenes e imágenes
docker-compose down -v --rmi all
```

## Comandos útiles con docker-compose
```bash
docker-compose up -d --build # Crear imagen y crear contenedores
docker-compose down -v --rmi all # Detener y eliminar contenedores, redes, volúmenes e imágenes
docker-compose down # Detener y eliminar contenedores
docker-compose down -v # Eliminar volúmenes (opcional)
docker-compose down --rmi all # Eliminar imágenes (opcional)
```

## Comandos útiles con docker

```bash
docker build -t <image> . # Crear imagen con docker
docker ps -a # Lista de contenedores
docker images ls # Listar todas las imagenes
docker container ls # Listar todos los contenedores
docker kill $(docker ps -q) # Eliminar todos los contenedores
docker rm $(docker container ls -q) --force # Eliminar todos los contenedores
docker rmi $(docker images -q) # Eliminar imagenes
docker container prune # Eliminar contenedores inutiles
docker image prune # Eliminar imagenes inutiles
docker network inspect bridge # Mostrar la red de docker
docker container inspect <id> # Mostrar información de un contenedor
docker container stop <id> # Detener un contenedor
docker system prune # Eliminar contenedores y imagen
docker system df # Ver espacio de disco
docker container exec -it <id> bash # Ejecutar comando en un contenedor
docker history <id> # Ver historial de un contenedor
docker network ls # Listar redes de docker
docker network remove <id> # Eliminar red de docker
docker pull <image> # Descargar imagen de docker
docker tag <image> <repository> # Crear tag para una imagen
docker update <id> # Actualizar un contenedor
docker update --restart=always <id> # Actualizar un contenedor
docker volume ls # Listar volumenes de docker
```

## Plantilla avanzada docker-compose
```bash
# Ejemplo estructura de un proyecto nodejs

my_project/
│
├── docker-compose.yml
└── web/
    ├── Dockerfile
    ├── package.json
    └── app.js
```

```bash
# Plantilla avanzada de Dockerfile

# Usar una imagen base oficial de Node.js con el tag especificando la versión de Node.js y el tipo de imagen (alpine es una versión más pequeña)
FROM node:18-alpine

# Establecer el directorio de trabajo en el contenedor
WORKDIR /usr/src/app

# Copiar los archivos de package.json y package-lock.json al directorio de trabajo
COPY package*.json ./

# Instalar las dependencias del proyecto. --silent suprime la salida del progreso y --only=production instala solo las dependencias de producción
RUN npm install --silent --only=production

# Copiar el resto de los archivos de la aplicación al directorio de trabajo
COPY . .

# Establecer una variable de entorno para el entorno de producción
ENV NODE_ENV=production

# Exponer el puerto que la aplicación va a usar
EXPOSE 3000

# Definir el comando por defecto para ejecutar la aplicación
CMD ["node", "app.js"]

# Añadir información adicional para la construcción del contenedor
LABEL maintainer="tu-email@example.com"
LABEL version="1.0"
LABEL description="Dockerfile avanzado para una aplicación Node.js."

# Definir argumentos de construcción que pueden ser pasados durante el build del contenedor
ARG NODE_VERSION=18
ARG NPM_VERSION=8

# Etiquetas de compilación para permitir mejor identificación y gestión de imágenes
LABEL build_date="2024-06-26"
LABEL com.example.version="1.0"
LABEL com.example.release-date="2024-06-26"
LABEL com.example.vendor="Your Company Name"
LABEL com.example.license="Apache-2.0"

# Optimización de caché de capas de Docker
# Instalar dependencias de desarrollo y construir la aplicación
# Después, eliminar las dependencias de desarrollo para mantener la imagen ligera
RUN npm install --silent && \
    npm run build && \
    npm prune --production

# Añadir usuarios y permisos (buena práctica de seguridad)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Cambiar al usuario no root
USER appuser

# Establecer punto de entrada (entrypoint) para el contenedor
ENTRYPOINT ["node"]

# Definir variables de entorno específicas para el tiempo de ejecución
ENV APP_HOME=/usr/src/app
ENV PATH=$APP_HOME/node_modules/.bin:$PATH

# Ejecutar cualquier script adicional si es necesario
# RUN ./scripts/setup.sh

# Limpieza de la imagen para reducir el tamaño
RUN apk add --no-cache bash && \
    apk add --no-cache --virtual .build-deps gcc g++ make python && \
    npm install --production && \
    apk del .build-deps

# Añadir metadatos adicionales (etiquetas de contenedor) para mejor gestión y seguimiento
LABEL org.opencontainers.image.source="https://github.com/tu-repo"
LABEL org.opencontainers.image.version="1.0"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# Establecer volumen (directorio persistente) si es necesario
VOLUME ["/usr/src/app/data"]

# Añadir comandos de depuración y testeo (solo para desarrollo)
# HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:3000/health || exit 1

```

```yaml
# Plantilla avanzada de docker-compose

version: '3.8'  # Especifica la versión de Docker Compose

services:
  web:
    image: node:18-alpine  # Usa una imagen base de Node.js
    container_name: web_container  # Nombre del contenedor
    build:  # Configuración para construir la imagen
      context: ./web  # Contexto de construcción, la carpeta 'web'
      dockerfile: Dockerfile  # Dockerfile dentro del contexto especificado
      args:  # Argumentos de construcción
        - NODE_ENV=production
    ports:
      - "3000:3000"  # Mapea el puerto 3000 del host al puerto 3000 del contenedor
    volumes:
      - ./web:/usr/src/app  # Monta el directorio actual en /usr/src/app dentro del contenedor
      - /usr/src/app/node_modules  # Para evitar conflictos de nodos de módulos entre host y contenedor
    environment:
      NODE_ENV: development  # Define una variable de entorno
    env_file:  # Archivos de variables de entorno
      - ./config.env
    command: ["node", "app.js"]  # Comando para ejecutar la aplicación
    depends_on:  # Define dependencias de otros servicios
      - db
    networks:
      - app_network  # Conecta este servicio a la red 'app_network'
    restart: always  # Reinicia siempre el contenedor si se detiene
    logging:  # Configuración de logging
      driver: json-file
      options:
        max-size: "10m"  # Tamaño máximo de un archivo de registro de logs 10mb
        max-file: "3"  # Docker mantendrá hasta 3 archivos de registro de logs, después eliminará el más antiguo

  db_postgresql:
    image: postgres:13  # Usa una imagen de PostgreSQL
    container_name: db_postgresql_container  # Nombre del contenedor
    environment:
      POSTGRES_DB: mydatabase  # Nombre de la base de datos
      POSTGRES_USER: user  # Usuario de la base de datos
      POSTGRES_PASSWORD: password  # Contraseña de la base de datos
    volumes:
      - db_data:/var/lib/postgresql/data  # Monta un volumen para persistir datos
    networks:
      - app_network  # Conecta este servicio a la red 'app_network'
    restart: unless-stopped  # Reinicia a menos que el contenedor se detenga manualmente
    
  db_mysql:
    image: mysql:8.0  # Usa una imagen de MySQL 8.0
    container_name: db_mysql_container  # Nombre del contenedor
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword  # Contraseña del usuario root
      MYSQL_DATABASE: mydatabase  # Nombre de la base de datos a crear
      MYSQL_USER: user  # Nombre de un usuario no-root
      MYSQL_PASSWORD: password  # Contraseña del usuario no-root
    volumes:
      - db_data:/var/lib/mysql  # Monta el volumen 'db_data' en el directorio de datos de MySQL
    networks:
      - app_network  # Conecta este servicio a la red 'app_network'
    restart: unless-stopped  # Reinicia a menos que el contenedor se detenga manualmente

  redis:
    image: redis:6  # Usa una imagen de Redis
    container_name: redis_container  # Nombre del contenedor
    ports:
      - "6379:6379"  # Mapea el puerto 6379 del host al puerto 6379 del contenedor
    networks:
      - app_network  # Conecta este servicio a la red 'app_network'
    restart: on-failure  # Reinicia solo si el contenedor falla

  nginx:
    image: nginx:latest  # Usa la imagen más reciente de Nginx
    container_name: nginx_container  # Nombre del contenedor
    ports:
      - "80:80"  # Mapea el puerto 80 del host al puerto 80 del contenedor
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf  # Monta un archivo de configuración Nginx
    networks:
      - app_network  # Conecta este servicio a la red 'app_network'
    depends_on:
      - web

volumes:
  db_data:  # Define un volumen llamado 'db_data'
    driver: local  # Driver para el volumen

networks:
  app_network:  # Define una red llamada 'app_network'
    driver: bridge  # Tipo de red

```