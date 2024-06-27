# Usa una imagen base oficial de Node.js
FROM node:18-alpine as alpineServer

# Crea un directorio de trabajo
WORKDIR /usr/src/app

# Copia los archivos package.json y package-lock.json
COPY package*.json ./

# Instala las dependencias del proyecto
RUN npm install

# Copia el código de la aplicación
COPY . .

# Expone el puerto que la aplicación usa
EXPOSE 3000

# Define el comando para ejecutar la aplicación
CMD ["node", "index.js"]
