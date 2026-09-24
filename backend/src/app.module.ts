import { Controller, Get, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { User } from './users/user.entity';
import { DashboardModule, Shipment } from './dashboard/dashboard.module';

@Controller('health')
class HealthController {
  @Get()
  check() {
    return { status: 'ok' };
  }
}

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      entities: [User, Shipment],
      // synchronize keeps setup to zero steps for the assessment; use migrations in production.
      synchronize: true,
      // Managed Postgres (Render/Railway) requires TLS; local Postgres usually does not.
      ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
    }),
    UsersModule,
    AuthModule,
    DashboardModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
