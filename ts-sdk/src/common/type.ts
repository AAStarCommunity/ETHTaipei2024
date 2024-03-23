export enum ENV {
    PROD = 'prod',
    DEV = 'dev'
}

export enum Method {
    GET = 'GET',
    POST = 'POST',
}

export interface BaseRequest {
}

export interface AuthRequest {
    apiKey: string
}

export interface UserOp {
    call_data: string
    call_gas_limit: string
    init_code: string
    max_fee_per_gas: string
    max_priority_fee_per_gas: string
    nonce: string
    pre_verification_gas: string
    sender: string
    signature: string
    verification_gas_limit: string
    paymaster_and_data: string
}

//entrypoint v0.6
export interface TryPayUserOpRequestV1 {
    user_operation: UserOp
    extra?: string
    force_entrypoint_address?: string
    force_network?: Network
    force_strategy_id?: string
    force_token?: Token
}


export interface BaseResponse {
    code: number
    message: string
    cost: string
}

export interface TryPayUserOpResponse extends BaseResponse {
    data: TryPayUserOpResult
}

export interface TryPayUserOpResult {
    strategy_id: string
    entrypoint_address: string
    paymaster_address: string
    paymaster_signature: string
    paymaster_and_data: string
    pay_receipt: Map<string, string>
    gas_info: Map<string, string>
}

export interface HealthResponse extends BaseResponse {
    data: Map<string, string>
}

export interface EntryPoint {
    address: string
    desc: string
    network: string
    strategy_id: string
}


export interface GetSupportEntryEntryPointResponse extends BaseResponse {
    data: EntryPoint[]
}

export interface GetSupportStrategyResponse extends BaseResponse {
    data: Map<string, any>
}

export interface AuthResponse {
    "code": number,
    "expire": string,
    "token": string
}

export enum Network {
    Ethereum = 'ethereum',
}

export enum Token {
    USDT = 'usdt',
    ETH = 'eth',
    Op = 'op',

}
