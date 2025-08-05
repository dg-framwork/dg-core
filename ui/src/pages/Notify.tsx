import { useEffect, useState } from "react";

interface Config {
    ui_scale: number;
}

interface Notification {
    id: string;
    message: string;
    type: 'success' | 'error' | 'warning' | 'info';
    timestamp: number;
}

// 通知コンポーネント
const NotificationItem = ({ notification, scale = 1 }: { notification: Notification; scale?: number }) => {
    const getTypeStyles = (type: string) => {
        switch (type) {
            case 'success':
                return {
                    borderColor: '#00ff88',
                    icon: '✅',
                    glowColor: '#00ff88'
                };
            case 'error':
                return {
                    borderColor: '#ff4757',
                    icon: '❌',
                    glowColor: '#ff4757'
                };
            case 'warning':
                return {
                    borderColor: '#ffa502',
                    icon: '⚠️',
                    glowColor: '#ffa502'
                };
            case 'info':
            default:
                return {
                    borderColor: '#3742fa',
                    icon: 'ℹ️',
                    glowColor: '#3742fa'
                };
        }
    };

    const styles = getTypeStyles(notification.type);

    return (
        <div style={{
            position: 'relative',
            width: `${320 * scale}px`,
            marginBottom: `${10 * scale}px`,
            backgroundColor: 'rgba(10, 20, 30, 0.85)',
            color: 'white',
            fontFamily: '"Orbitron", sans-serif',
            fontSize: `${14 * scale}px`,
            letterSpacing: `${0.5 * scale}px`,
            textShadow: `0 0 ${5 * scale}px rgba(0,0,0,0.8)`,
            animation: 'slideIn 0.5s ease-out',
            clipPath: 'polygon(0 0, calc(100% - 20px) 0, 100% 20px, 100% 100%, 0 100%)',
            border: `${1 * scale}px solid ${styles.borderColor}`,
            boxShadow: `0 0 ${15 * scale}px ${styles.glowColor}50`,
            padding: `${12 * scale}px ${16 * scale}px`,
            overflow: 'hidden',
            wordWrap: 'break-word',
        }}>
            <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: `${12 * scale}px`,
            }}>
                <span style={{ 
                    fontSize: `${20 * scale}px`, 
                    textShadow: `0 0 ${10 * scale}px ${styles.glowColor}`
                }}>
                    {styles.icon}
                </span>
                <span style={{ flex: 1, fontWeight: 'bold' }}>{notification.message}</span>
            </div>
            
            {/* Progress bar for auto-remove */}
            <div style={{
                position: 'absolute',
                bottom: 0,
                left: 0,
                height: `${3 * scale}px`,
                width: '100%',
                backgroundColor: 'rgba(0,0,0,0.4)',
            }}>
                <div style={{
                    height: '100%',
                    backgroundColor: styles.glowColor,
                    animation: 'shrink 5s linear forwards',
                    boxShadow: `0 0 ${5 * scale}px ${styles.glowColor}`
                }} />
            </div>
        </div>
    );
};

function Notify() {
    const [config, setConfig] = useState<Config | null>(null);
    const [visible, setVisible] = useState<boolean>(true);
    const [notifications, setNotifications] = useState<Notification[]>([]);

    const showNotification = (message: string, type: Notification["type"] = "info") => {
        const id = Date.now().toString() + Math.random().toString(36).substr(2, 9);
        const newNotification: Notification = {
            id,
            message,
            type,
            timestamp: Date.now()
        };

        setNotifications(prev => [...prev, newNotification]);

        setTimeout(() => {
            setNotifications(prev => prev.filter(n => n.id !== id));
        }, 5000);
    };

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.action == "syncConfig") {
                setConfig(event.data.config)
            }

            if (event.data.action == "showNotify") {
                setVisible(true);
            }

            if (event.data.action == "hideNotify") {
                setVisible(false);
            }

            if (event.data.action == "notify") {
                const message = event.data.message;
                const type = event.data.type || 'info';
                showNotification(message, type)
            }
        }

        window.addEventListener("message", handleMessage);
        return () => window.removeEventListener("message", handleMessage)
    }, []);

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
            {/* 通知エリア */}
            <div style={{
                position: 'absolute',
                top: `${20 * scale}px`,
                right: `${20 * scale}px`,
                zIndex: 1001,
                pointerEvents: 'none',
            }}>
                {notifications.map(notification => (
                    <NotificationItem
                        key={notification.id}
                        notification={notification}
                        scale={scale}
                    />
                ))}
            </div>
        </div>
    )
}

export default Notify;