import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import { Response } from 'express';

/**
 * Every error leaves the API as { statusCode, error, message, details? } so the
 * client only handles one shape. Validation errors put per-field messages in `details`.
 */
@Catch()
export class HttpErrorFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();
    const status = exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let details: string[] | undefined;

    if (exception instanceof HttpException) {
      const body = exception.getResponse() as any;
      if (Array.isArray(body?.message)) {
        message = 'Validation failed';
        details = body.message;
      } else {
        message = body?.message ?? exception.message;
      }
    } else {
      console.error(exception);
    }

    res.status(status).json({
      statusCode: status,
      error: HttpStatus[status] ?? 'ERROR',
      message,
      ...(details && { details }),
    });
  }
}
