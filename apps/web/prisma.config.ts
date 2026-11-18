import path from 'node:path';
import { config } from 'dotenv';
import { defineConfig, env } from 'prisma/config';

config({ path: path.resolve(process.cwd(), '../../.env.local') });
config({ path: '.env.local' });
config();

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    url: env('DATABASE_URL'),
  },
});
