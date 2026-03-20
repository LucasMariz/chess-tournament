import IORedis from 'ioredis'

export const redis = new IORedis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
  maxRetriesPerRequest: null,
})

redis.on('connect', () => console.log('Redis conectado'))
redis.on('error', (err) => console.error('Redis error:', err))