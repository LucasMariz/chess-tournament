import Fastify from 'fastify'
import cors from '@fastify/cors'
import { AppError } from './lib/errors'

import prismaPlugin from './plugins/prisma.plugin'
import redisPlugin from './plugins/redis.plugin'
import authPlugin from './plugins/auth.plugin'

const server = Fastify({
  logger: {
    transport: {
      target: 'pino-pretty',
      options: { colorize: true },
    },
  },
})

// Plugins
server.register(cors, {
  origin: process.env.FRONTEND_URL ?? 'http://localhost:5173',
  credentials: true,
})
server.register(prismaPlugin)
server.register(redisPlugin)
server.register(authPlugin)

// Health check
server.get('/health', async () => ({
  status: 'ok',
  timestamp: new Date().toISOString(),
}))

// Tratamento global de erros
server.setErrorHandler((error, request, reply) => {
  if (error instanceof AppError) {
    return reply.status(error.statusCode).send({
      error: error.code ?? 'ERROR',
      message: error.message,
    })
  }

  server.log.error(error)
  return reply.status(500).send({
    error: 'INTERNAL_SERVER_ERROR',
    message: 'Erro interno do servidor',
  })
})

// Inicializar
const start = async () => {
  try {
    const port = Number(process.env.PORT) ?? 3333
    await server.listen({ port, host: '0.0.0.0' })
  } catch (err) {
    server.log.error(err)
    process.exit(1)
  }
}

start()