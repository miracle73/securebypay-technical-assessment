import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

export type CreateUserInput = Pick<User, 'firstName' | 'lastName' | 'email' | 'phone' | 'passwordHash'> &
  Partial<Pick<User, 'walletBalance'>>;

@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private readonly users: Repository<User>) {}

  findById(id: string) {
    return this.users.findOneBy({ id });
  }

  existsByEmail(email: string) {
    return this.users.existsBy({ email });
  }

  /** `passwordHash` is excluded from default selects, so it is opted in here. */
  findByEmailWithPassword(email: string) {
    return this.users
      .createQueryBuilder('user')
      .addSelect('user.passwordHash')
      .where('user.email = :email', { email })
      .getOne();
  }

  create(input: CreateUserInput) {
    return this.users.save(this.users.create(input));
  }
}
