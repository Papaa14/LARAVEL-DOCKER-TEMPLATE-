<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Laravel\Socialite\Facades\Socialite;

class SocialLoginController extends Controller
{
    public function redirect($provider)
    {
        return Socialite::driver($provider)->redirect();
    }

    public function callback($provider)
    {
        try {
             /** @var \Laravel\Socialite\Two\User $socialUser */
            $socialUser = Socialite::driver($provider)->user();

            $user = User::where('email', $socialUser->email)->first();

            if ($user) {
                if (!$user->provider_name) {
                    $user->update([
                        'provider_name' => $provider,
                        'provider_id' => $socialUser->id,
                    ]);
                }
                Auth::login($user);
            } else {
                $user = User::create([
                    'name' => $socialUser->name,
                    'email' => $socialUser->email,
                    'password' => Hash::make(Str::random(8)),
                    'provider_name' => $provider,
                    'provider_id' => $socialUser->id,
                    'email_verified_at' => now(),
                ]);
                Auth::login($user);
            }

            return redirect()->intended('/dashboard');
        } catch (\Exception $e) {
            return redirect('/login')->with('error', 'Authentication failed');
        }
    }
}
