import 'reflect-metadata';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

function corsOrigin(raw?: string): boolean | string[] {
  const origins = raw?.split(',').map((o) => o.trim()).filter(Boolean) ?? [];
  return origins.length === 0 || origins.includes('*') ? true : origins;
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = app.get(ConfigService);

  app.setGlobalPrefix('api');
  app.enableCors({ origin: corsOrigin(config.get('CORS_ORIGINS')) });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new HttpExceptionFilter());

  await app.listen(config.get<number>('PORT') ?? 3000, '0.0.0.0');
}

bootstrap();
