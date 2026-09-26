import { TransformFnParams } from 'class-transformer';

const whenString = (fn: (v: string) => string) => ({ value }: TransformFnParams) =>
  typeof value === 'string' ? fn(value) : value;

export const trim = whenString((v) => v.trim());
export const normalizeEmail = whenString((v) => v.trim().toLowerCase());
export const stripPhoneSeparators = whenString((v) => v.replace(/[\s-]/g, ''));
