<?php

// autoload_static.php @generated by Composer

namespace Composer\Autoload;

class ComposerStaticInit1c4817abad6e0fd7fb1c499d82ddd4da
{
    public static $prefixLengthsPsr4 = array (
        'P' => 
        array (
            'Pushok\\' => 7,
            'Psr\\Http\\Message\\' => 17,
            'Psr\\Http\\Client\\' => 16,
        ),
        'J' => 
        array (
            'Jose\\Component\\Signature\\Algorithm\\' => 35,
            'Jose\\Component\\Signature\\' => 25,
            'Jose\\Component\\KeyManagement\\' => 29,
            'Jose\\Component\\Core\\' => 20,
        ),
        'F' => 
        array (
            'FG\\' => 3,
        ),
        'B' => 
        array (
            'Brick\\Math\\' => 11,
            'Base64Url\\' => 10,
        ),
    );

    public static $prefixDirsPsr4 = array (
        'Pushok\\' => 
        array (
            0 => __DIR__ . '/..' . '/edamov/pushok/src',
        ),
        'Psr\\Http\\Message\\' => 
        array (
            0 => __DIR__ . '/..' . '/psr/http-factory/src',
            1 => __DIR__ . '/..' . '/psr/http-message/src',
        ),
        'Psr\\Http\\Client\\' => 
        array (
            0 => __DIR__ . '/..' . '/psr/http-client/src',
        ),
        'Jose\\Component\\Signature\\Algorithm\\' => 
        array (
            0 => __DIR__ . '/..' . '/web-token/jwt-signature-algorithm-ecdsa',
        ),
        'Jose\\Component\\Signature\\' => 
        array (
            0 => __DIR__ . '/..' . '/web-token/jwt-signature',
        ),
        'Jose\\Component\\KeyManagement\\' => 
        array (
            0 => __DIR__ . '/..' . '/web-token/jwt-key-mgmt',
        ),
        'Jose\\Component\\Core\\' => 
        array (
            0 => __DIR__ . '/..' . '/web-token/jwt-core',
        ),
        'FG\\' => 
        array (
            0 => __DIR__ . '/..' . '/fgrosse/phpasn1/lib',
        ),
        'Brick\\Math\\' => 
        array (
            0 => __DIR__ . '/..' . '/brick/math/src',
        ),
        'Base64Url\\' => 
        array (
            0 => __DIR__ . '/..' . '/spomky-labs/base64url/src',
        ),
    );

    public static function getInitializer(ClassLoader $loader)
    {
        return \Closure::bind(function () use ($loader) {
            $loader->prefixLengthsPsr4 = ComposerStaticInit1c4817abad6e0fd7fb1c499d82ddd4da::$prefixLengthsPsr4;
            $loader->prefixDirsPsr4 = ComposerStaticInit1c4817abad6e0fd7fb1c499d82ddd4da::$prefixDirsPsr4;

        }, null, ClassLoader::class);
    }
}
