import {
  Body, ConflictException, Controller, Get, HttpCode, Injectable, Module, Post, Req,
  UnauthorizedException, UseGuards,
} from '@nestjs/common';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { AuthGuard, PassportModule, PassportStrategy } from '@nestjs/passport';
import * as bcrypt from 'bcryptjs';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { User } from '../users/user.entity';
import { UsersModule, UsersService } from '../users/users.module';
import { DashboardModule, DashboardService } from '../dashboard/dashboard.module';
import { LoginDto, RegisterDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
    private readonly dashboard: DashboardService,
  ) {}

  async register(dto: RegisterDto) {
    if (await this.users.findByEmailWithPassword(dto.email)) {
      throw new ConflictException('An account with this email already exists');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    const { password, ...profile } = dto;
    // Demo opening balance so the wallet card matches the design.
    const user = await this.users.create({ ...profile, passwordHash, walletBalance: '3000000.28' });
    await this.dashboard.seedFor(user);
    return this.session(user);
  }

  async login(dto: LoginDto) {
    const user = await this.users.findByEmailWithPassword(dto.email);
    // Same message for unknown email and wrong password to avoid account enumeration.
    if (!user || !(await bcrypt.compare(dto.password, user.passwordHash))) {
      throw new UnauthorizedException('Invalid email or password');
    }
    return this.session(user);
  }

  private session(user: User) {
    const { passwordHash, ...safe } = user;
    return { accessToken: this.jwt.sign({ sub: user.id, email: user.email }), user: safe };
  }
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly users: UsersService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  // Re-load the user so a token for a deleted account is rejected.
  async validate(payload: { sub: string }) {
    const user = await this.users.findById(payload.sub);
    if (!user) throw new UnauthorizedException();
    return user;
  }
}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Post('login')
  @HttpCode(200)
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  /** Protected: returns the user resolved from the Bearer token. */
  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  me(@Req() req: { user: User }) {
    return req.user;
  }
}

@Module({
  imports: [
    UsersModule,
    DashboardModule,
    PassportModule,
    JwtModule.registerAsync({
      useFactory: () => ({
        secret: process.env.JWT_SECRET,
        signOptions: { expiresIn: process.env.JWT_EXPIRES_IN || '1d' },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
})
export class AuthModule {}
