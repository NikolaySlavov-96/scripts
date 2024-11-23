FROM node:20

WORKDIR /usr/app

COPY package*.json ./

RUN npm install

COPY . .

# RUN npm run build

RUN chmod +x /usr/app/script.sh

CMD ["bash", "/usr/app/script.sh"]