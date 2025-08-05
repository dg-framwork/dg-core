import { useEffect, useState } from "react";

interface Config {
    ui_scale: number;
    ui_damage: boolean;
}

interface Position {
    x: number;
    y: number;
    z: number;
}

interface User {
    id: string;
    license: string;
    username: string;
    is_admin: boolean;
    is_ban: boolean;
    ban_reason: string;
    is_whitelist: boolean;
    note: string;
    health: string;
    armour: string;
    stamina: string;
    position: Position;
}

interface DamageDisplay {
    damage: number;
    timestamp: number;
}

// バーのコンポーネント
const ProgressBar = ({
    value,
    max,
    color,
    label,
    icon,
    scale = 1
}: {
    value: number;
    max: number;
    color: string;
    label: string;
    icon: string;
    scale?: number;
}) => {
    const percentage = Math.min((value / max) * 100, 100);

    return (
        <div style={{ 
            marginBottom: `${12 * scale}px`, 
            width: `${220 * scale}px` 
        }}>
            <div style={{
                display: 'flex',
                alignItems: 'center',
                marginBottom: `${5 * scale}px`,
                color: 'white',
                fontFamily: '"Orbitron", sans-serif',
                textTransform: 'uppercase',
                fontSize: `${14 * scale}px`,
                letterSpacing: `${1 * scale}px`,
            }}>
                <span style={{ 
                    fontSize: `${20 * scale}px`, 
                    marginRight: `${10 * scale}px`, 
                    textShadow: `0 0 ${8 * scale}px ${color}` 
                }}>{icon}</span>
                <span>{label}</span>
                <span style={{ marginLeft: 'auto', fontWeight: 'bold' }}>{Math.round(value)}</span>
            </div>
            <div style={{
                height: `${12 * scale}px`,
                backgroundColor: 'rgba(0, 0, 0, 0.5)',
                borderRadius: `${3 * scale}px`,
                overflow: 'hidden',
                border: `${1 * scale}px solid rgba(255, 255, 255, 0.2)`,
                position: 'relative',
            }}>
                <div style={{
                    width: `${percentage}%`,
                    height: '100%',
                    backgroundColor: color,
                    borderRadius: `${2 * scale}px`,
                    transition: 'width 0.5s cubic-bezier(0.25, 1, 0.5, 1)',
                    boxShadow: `inset 0 0 ${5 * scale}px rgba(0,0,0,0.5), 0 0 ${10 * scale}px ${color}`,
                }} />
                {/* Adding a subtle gloss effect */}
                <div style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    width: '100%',
                    height: '50%',
                    background: 'linear-gradient(to bottom, rgba(255,255,255,0.2), transparent)',
                }}/>
            </div>
        </div>
    );
};

// ダメージ表示コンポーネント
const DamageDisplay = ({ damage, scale = 1 }: { damage: number; scale?: number }) => {
    return (
        <div style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            fontSize: `${48 * scale}px`,
            fontWeight: 'bold',
            color: '#ff4757',
            fontFamily: '"Orbitron", sans-serif',
            textShadow: `0 0 ${20 * scale}px #ff4757, 0 0 ${40 * scale}px #ff4757`,
            animation: 'damagePop 0.3s ease-out, damageFade 2s ease-out forwards',
            zIndex: 1002,
            pointerEvents: 'none',
        }}>
            -{damage}
        </div>
    );
};

function Status() {
    const [config, setConfig] = useState<Config | null>(null);
    const [visible, setVisible] = useState<boolean>(true);
    const [user, setUser] = useState<User | null>(null);
    const [damageDisplay, setDamageDisplay] = useState<DamageDisplay | null>(null);

    const showDamage = (damage: number) => {
        setDamageDisplay({ damage, timestamp: Date.now() });
    };

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.action === "showStatus") {
                setVisible(true);
            }

            if (event.data.action === "hideStatus") {
                setVisible(false);
            }

            if (event.data.action === "syncUser") {
                setUser(event.data.user);
            }

            if (event.data.action === "syncConfig") {
                setConfig(event.data.config);
            }

            if (event.data.action === "damage") {
                const damage = event.data.damage;
                showDamage(damage);
            }
        };

        window.addEventListener("message", handleMessage);
        return () => window.removeEventListener("message", handleMessage);
    }, []);

    // ダメージ表示の自動削除
    useEffect(() => {
        if (damageDisplay) {
            const timer = setTimeout(() => {
                setDamageDisplay(null);
            }, 2000);

            return () => clearTimeout(timer);
        }
    }, [damageDisplay]);

    // FiveM health is 100 (min) to 200 (max). We map this to 0-100 for the bar.
    const rawHpValue = parseInt(user?.health || '100');
    const hpValue = Math.max(0, rawHpValue);
    const armourValue = parseInt(user?.armour || '0');
    const staminaValue = Math.max(0, Math.min(100, Math.round(parseFloat(user?.stamina || '0'))));

    if (!visible) return null;
    
    const scale = config?.ui_scale || 1;
    
    return (
        <div style={{
            position: 'fixed',
            width: '100%',
            height: '100%',
            pointerEvents: 'none',
            zIndex: 1000,
            color: 'white',
            fontFamily: '"Orbitron", sans-serif', // Game-like font
            textShadow: `0 0 ${5 * scale}px rgba(0,0,0,0.7)`,
        }}>
            {/* To use the Orbitron font, add this to your index.html <head>:
            <link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap" rel="stylesheet">
            */}

            {/* ダメージ表示 */}
            {config?.ui_damage && damageDisplay && (
                <DamageDisplay damage={damageDisplay.damage} scale={scale} />
            )}

            {/* Left Hud */}
            <div style={{
                position: 'absolute',
                bottom: `${20 * scale}px`,
                left: `${20 * scale}px`,
                padding: `${15 * scale}px`,
                backgroundColor: 'rgba(10, 20, 30, 0.75)',
                border: `${1 * scale}px solid rgba(0, 190, 255, 0.5)`,
                // backdropFilter: 'blur(8px)',
                clipPath: 'polygon(0 0, calc(100% - 20px) 0, 100% 20px, 100% 100%, 0 100%)',
                boxShadow: `0 0 ${20 * scale}px rgba(0, 190, 255, 0.2)`,
            }}>
                <ProgressBar
                    value={hpValue}
                    max={100}
                    color="#e84118" // Vibrant Red
                    label="Health"
                    icon="❤️"
                    scale={scale}
                />
                <ProgressBar
                    value={armourValue}
                    max={100}
                    color="#0097e6" // Vibrant Blue
                    label="Armor"
                    icon="🛡️"
                    scale={scale}
                />
                <ProgressBar
                    value={staminaValue}
                    max={100}
                    color="#ffae00ff" // Vibrant Blue
                    label="Stamina"
                    icon="⚡"
                    scale={scale}
                />
            </div>

            {/* Right Hud */}
            <div style={{
                position: 'absolute',
                bottom: `${20 * scale}px`,
                right: `${20 * scale}px`,
                padding: `${10 * scale}px ${20 * scale}px`,
                backgroundColor: 'rgba(10, 20, 30, 0.75)',
                border: `${1 * scale}px solid rgba(0, 190, 255, 0.5)`,
                // backdropFilter: 'blur(8px)',
                clipPath: 'polygon(0 20px, 20px 0, 100% 0, 100% 100%, 0 100%)',
                boxShadow: `0 0 ${20 * scale}px rgba(0, 190, 255, 0.2)`,
                display: 'flex',
                alignItems: 'center',
                fontSize: `${18 * scale}px`,
                fontWeight: 'bold',
                letterSpacing: `${1.5 * scale}px`,
            }}>
                <span style={{ color: '#00beff', marginRight: `${10 * scale}px` }}>ID:</span>
                <span>{user?.id || 'N/A'}</span>
            </div>

            {/* CSS Animations */}
            <style>{`
                @keyframes slideIn {
                    from {
                        transform: translateX(100%);
                        opacity: 0;
                    }
                    to {
                        transform: translateX(0);
                        opacity: 1;
                    }
                }
                
                @keyframes shrink {
                    from {
                        width: 100%;
                    }
                    to {
                        width: 0%;
                    }
                }

                @keyframes damagePop {
                    0% {
                        transform: translate(-50%, -50%) scale(0.5);
                        opacity: 0;
                    }
                    50% {
                        transform: translate(-50%, -50%) scale(1.2);
                        opacity: 1;
                    }
                    100% {
                        transform: translate(-50%, -50%) scale(1);
                        opacity: 1;
                    }
                }

                @keyframes damageFade {
                    0% {
                        opacity: 1;
                    }
                    70% {
                        opacity: 1;
                    }
                    100% {
                        opacity: 0;
                    }
                }
            `}</style>
        </div>
    );
}

export default Status;