import fp from 'fastify-plugin'
import jwt, { FastifyJWTOptions } from '@fastify/jwt'
import { FastifyPluginAsync, FastifyRequest, FastifyReply } from 'fastify'
import { UnauthorizedError } from '../lib/errors'

const authPlugin: FastifyPluginAsync = fp(async (server) => {
  server.register(jwt, {
    secret: process.env.JWT_SECRET ?? 'fallback-secret',
  } as FastifyJWTOptions)

  server.decorate(
    'authenticate',
    async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        await request.jwtVerify()
      } catch {
        throw new UnauthorizedError()
      }
    }
  )
})

export default authPlugin