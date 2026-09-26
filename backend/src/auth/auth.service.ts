import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { DashboardService } from '../dashboard/dashboard.service';
import { User } from '../users/user.entity';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './jwt.strategy';

const BCRYPT_ROUNDS = 10;
const DEMO_OPENING_BALANCE = '3000000.28';

export interface AuthResponse {
  accessToken: string;
  user: Omit<User, 'passwordHash'>;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly dashboard: DashboardService,
  ) {}

  async register({ password, ...profile }: RegisterDto): Promise<AuthResponse> {
    if (await this.users.existsByEmail(profile.email)) {
      throw new ConflictException('An account with this email already exists');
    }

    const user = await this.users.create({
      ...profile,
      passwordHash: await bcrypt.hash(password, BCRYPT_ROUNDS),
      walletBalance: DEMO_OPENING_BALANCE,
    });
    await this.dashboard.seedDemoShipments(user);

    return this.issueSession(user);
  }

  async login({ email, password }: LoginDto): Promise<AuthResponse> {
    const user = await this.users.findByEmailWithPassword(email);
    const valid = user && (await bcrypt.compare(password, user.passwordHash));

    // One message for both cases so the endpoint can't be used to discover accounts.
    if (!valid) throw new UnauthorizedException('Invalid email or password');

    return this.issueSession(user);
  }

  private issueSession({ passwordHash: _, ...user }: User): AuthResponse {
    const payload: JwtPayload = { sub: user.id, email: user.email };
    return { accessToken: this.jwt.sign(payload), user };
  }
}
