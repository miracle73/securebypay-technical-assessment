import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { HttpErrorFilter } from './common/http-error.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  // CORS_ORIGINS is a comma-separated allowlist; unset means allow all (local dev only).
  const origins = process.env.CORS_ORIGINS?.split(',').map((o) => o.trim()).filter(Boolean);
  app.enableCors({ origin: origins?.length ? origins : true });
  app.setGlobalPrefix('api');
  // whitelist strips unknown fields; forbidNonWhitelisted rejects them with a 400.
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new HttpErrorFilter());
  await app.listen(process.env.PORT || 3000, '0.0.0.0');
}
bootstrap();
