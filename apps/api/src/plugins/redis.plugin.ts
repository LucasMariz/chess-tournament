import fp from 'fastify-plugin'
import { FastifyPluginAsync } from 'fastify'
import { redis } from '../lib/redis'

const redisPlugin: FastifyPluginAsync = fp(async (server) => {
  server.decorate('redis', redis)

  server.addHook('onClose', async () => {
    await redis.quit()
  })
})

export default redisPlugin