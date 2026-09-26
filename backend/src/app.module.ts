import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { validateEnv } from './config/env.validation';
import { DashboardModule } from './dashboard/dashboard.module';
import { HealthController } from './health/health.controller';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnv }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.getOrThrow<string>('DATABASE_URL'),
        ssl: config.get('DATABASE_SSL') === 'true' ? { rejectUnauthorized: false } : false,
        autoLoadEntities: true,
        // Schema sync keeps local setup to one step. Swap for migrations before real traffic.
        synchronize: true,
      }),
    }),
    UsersModule,
    AuthModule,
    DashboardModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
