import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Response } from 'express';

interface ErrorBody {
  statusCode: number;
  error: string;
  message: string;
  details?: string[];
}

/**
 * Normalises every error to `{ statusCode, error, message, details? }`.
 * Validation failures carry the per-field messages in `details`.
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();
    const body = this.toBody(exception);
    res.status(body.statusCode).json(body);
  }

  private toBody(exception: unknown): ErrorBody {
    if (!(exception instanceof HttpException)) {
      this.logger.error(exception);
      return { statusCode: 500, error: HttpStatus[500], message: 'Internal server error' };
    }

    const statusCode = exception.getStatus();
    const error = HttpStatus[statusCode] ?? 'ERROR';
    const response = exception.getResponse();
    const message = typeof response === 'object' ? (response as { message?: unknown }).message : response;

    if (Array.isArray(message)) {
      return { statusCode, error, message: 'Validation failed', details: message.map(String) };
    }
    return { statusCode, error, message: String(message ?? exception.message) };
  }
}
