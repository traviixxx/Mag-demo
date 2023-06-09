FROM node:16 as builder
WORKDIR /app
COPY nextjs ./
RUN npm run build

FROM node:16 as runner
WORKDIR /app
COPY nextjs/package.json ./package.json
COPY nextjs/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
EXPOSE 3000
ENV NODE_OPTIONS=--max-old-space-size=1536
CMD ["npm", "start"]
