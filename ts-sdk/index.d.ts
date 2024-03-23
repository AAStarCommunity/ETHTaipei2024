import {
    AuthResponse,
    BaseRequest,
    BaseResponse,
    ENV, GetSupportEntryEntryPointResponse, GetSupportStrategyResponse,
    HealthResponse,
    Method, Network,
    TryPayUserOpRequestV1,
    TryPayUserOpResponse
} from "./src/common/type";

declare class EthPaymasterClient {
    constructor(baseURL: string, fetcher: typeof fetch, env: ENV);

    static production(baseUrl?: string, fetcher: typeof fetch = fetch): EthPaymasterClient;

    static development(baseUrl?: string, fetcher: typeof fetch = fetch): EthPaymasterClient;

    health(): Promise<HealthResponse>;

    auth(apiKey: string): Promise<AuthResponse>;

    tryPayUserOperationV1(accessToken: string, request: TryPayUserOpRequestV1): Promise<TryPayUserOpResponse>;

    getSupportEntryPointV1(network: Network, accessToken: string): Promise<GetSupportEntryEntryPointResponse>;

    getSupportStrategyV1(network: Network, accessToken: string): Promise<GetSupportStrategyResponse>;
}