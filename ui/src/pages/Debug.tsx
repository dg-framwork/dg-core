import { useEffect, useState } from "react";

interface Position {
    x: number;
    y: number;
    z: number;
}

type Metadata = {
    [key: string]: unknown;
}

interface Config {
    Closed: boolean;
    Whitelist: boolean;
    Redis: boolean;
    ChunkSize: number;
    UseAsyncQuery: boolean;
    MaxQueries: number;
    Debug: boolean;
}

interface User {
    id: string;
    license: string;
    username: string;
    is_admin: number;       // 1 == true / 0 == false
    is_ban: number;         // 1 == true / 0 == false
    ban_reason: string;
    is_whitelist: number;   // 1 == true / 0 == false
    position: Position;
    metadata: Metadata;
    health: number;
    armour: number;
    stamina: number;
    is_online: boolean;
    is_restrained: boolean;
    source: number;
}

interface Item {
    id: string;
    label: string;
    description: string;
    category: string;
    image: string;
    is_stack: number;       // 1 == true / 0 == false
    max_stack: number;
    unique: number;         // 1 == true / 0 == false
    hash: string;
}

function Debug() {
    const [visible, setVisible] = useState<boolean | null>(null);
    const [config, setConfig] = useState<Config | null>(null);
    const [user, setUser] = useState<User | null>(null);
    const [users, setUsers] = useState<User[] | null>(null);
    const [items, setItems] = useState<Item[] | null>(null);

    const handleRefresh = () => {
        fetch(`https://${GetParentResourceName()}/refreshDebug`, {
            method: "POST",
            headers: { "Content-Type": "application/json"},
            body: JSON.stringify({}),
        }).catch(err => console.log("Failed to refresh debug data: ", err))
    }

    useEffect(() => {
        window.addEventListener("message", (event: MessageEvent) => {
            if (event.data.action === "DGCORE:NUI:Debug:Show") {
                setVisible(true);
            }

            if (event.data.action === "DGCORE:NUI:Debug:Hide") {
                setVisible(false);
            }

            if (event.data.action === "DGCORE:NUI:Debug:Config") {
                setConfig(event.data.config);
            }

            if (event.data.action === "DGCORE:NUI:Debug:User") {
                setUser(event.data.user);
            }

            if (event.data.action === "DGCORE:NUI:Debug:Users") {
                setUsers(event.data.users);
            }

            if (event.data.action === "DGCORE:NUI:Debug:Items") {
                setItems(event.data.items);
            }
        });
    }, []);

    if (!visible) return null;

    const renderObject = (title: string, data: object | null) => (
        <div style={{ marginBottom: '20px', padding: '10px', backgroundColor: '#333' }}>
            <h2>{title}</h2>
            {data ? (
                <pre style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-all', color: 'white' }}>
                    {JSON.stringify(data, null, 2)}
                </pre>
            ) : <p>No data.</p>}
        </div>
    );

    const tableHeaderStyle = { border: '1px solid #555', padding: '8px', textAlign: 'left' as const, backgroundColor: '#444' };
    const tableCellStyle = { border: '1px solid #555', padding: '8px', verticalAlign: 'top' };

    return (
        <div style={{ padding: '20px', backgroundColor: 'rgba(0, 0, 0, 0.9)', color: 'white', height: '100vh', overflowY: 'auto', fontFamily: 'monospace' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid #555', paddingBottom: '10px' }}>
                <h1 style={{ margin: 0 }}>DGCore Debug Panel</h1>
                <button onClick={handleRefresh} style={{ padding: '10px 20px', cursor: 'pointer', backgroundColor: '#555', border: 'none', color: 'white', borderRadius: '5px' }}>
                    Refresh
                </button>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '20px' }}>
                {renderObject("User", user)}
                {renderObject("Config[Server]", config)}
            </div>

            <div style={{ marginTop: '20px' }}>
                <h2>Users</h2>
                {users && users.length > 0 ? (
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr>
                                <th style={tableHeaderStyle}>ID</th>
                                <th style={tableHeaderStyle}>Username</th>
                                <th style={tableHeaderStyle}>Admin</th>
                                <th style={tableHeaderStyle}>Whitelisted</th>
                                <th style={tableHeaderStyle}>Banned</th>
                                <th style={tableHeaderStyle}>Health</th>
                                <th style={tableHeaderStyle}>Armour</th>
                                <th style={tableHeaderStyle}>Position</th>
                            </tr>
                        </thead>
                        <tbody>
                            {users.map(user => (
                                <tr key={user.id}>
                                    <td style={tableCellStyle}>{user.id}</td>
                                    <td style={tableCellStyle}>{user.username}</td>
                                    <td style={tableCellStyle}>{user.is_admin ? 'Yes' : 'No'}</td>
                                    <td style={tableCellStyle}>{user.is_whitelist ? 'Yes' : 'No'}</td>
                                    <td style={tableCellStyle}>{user.is_ban ? `Yes (${user.ban_reason})` : 'No'}</td>
                                    <td style={tableCellStyle}>{user.health}</td>
                                    <td style={tableCellStyle}>{user.armour}</td>
                                    <td style={tableCellStyle}>{`(${user.position.x}, ${user.position.y}, ${user.position.z})`}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : <p>No user data.</p>}
            </div>

            <div style={{ marginTop: '20px' }}>
                <h2>Items</h2>
                {items && items.length > 0 ? (
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                        <thead>
                            <tr>
                                <th style={tableHeaderStyle}>Image</th>
                                <th style={tableHeaderStyle}>Label</th>
                                <th style={tableHeaderStyle}>Description</th>
                                <th style={tableHeaderStyle}>Category</th>
                                <th style={tableHeaderStyle}>Stackable</th>
                                <th style={tableHeaderStyle}>Hash</th>
                            </tr>
                        </thead>
                        <tbody>
                            {items.map(item => (
                                <tr key={item.id}>
                                    <td style={tableCellStyle}><img src={`images/items/weapons/${item.image}`} alt={item.label} style={{ width: '50px', height: '50px', objectFit: 'contain' }} /></td>
                                    <td style={tableCellStyle}>{item.label}</td>
                                    <td style={tableCellStyle}>{item.description}</td>
                                    <td style={tableCellStyle}>{item.category}</td>
                                    <td style={tableCellStyle}>{item.is_stack ? `Yes (${item.max_stack})` : 'No'}</td>
                                    <td style={tableCellStyle}>{item.hash}</td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                ) : <p>No item data.</p>}
            </div>
        </div>
    );
}

export default Debug;