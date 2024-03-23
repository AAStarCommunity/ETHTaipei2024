# EthPaymaster_sdk_ts
EthPaymaster typescript Sdk

```tsx
let client = EthPaymasterClient.development(address)
 
const healthResponse = await client.health()
   
const authResponse = await client.auth("API-KEY")
  
const token = authResponse.token
  
const strategyResponse = await client.getSupportStrategyV1(Network.Ethereum, authResponse.token) 
  
const entrypointResponse = await client.getSupportEntryPointV1(Network.Ethereum, authResponse.token)
 
const request: TryPayUserOpRequestV1 = {
            force_strategy_id: "1",
            user_operation: {
                call_data: "0xb61d27f6000000000000000000000000c206b552ab127608c3f666156c8e03a8471c72df000000000000000000000000000000000000000000000000002386f26fc1000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000",
                call_gas_limit: "39837",
                init_code: "0xe19e9755942bb0bd0cccce25b1742596b8a8250b3bf2c3e700000000000000000000000078d4f01f56b982a3b03c4e127a5d3afa8ebee6860000000000000000000000008b388a082f370d8ac2e2b3997e9151168bd09ff50000000000000000000000000000000000000000000000000000000000000000",
                max_fee_per_gas: "44020",
                max_priority_fee_per_gas: "1743509478",
                nonce: "1",
                pre_verification_gas: "44020",
                sender: "0x4A2FD3215420376DA4eD32853C19E4755deeC4D1",
                signature: "0x760868cd7d9539c6e31c2169c4cab6817beb8247516a90e4301e929011451658623455035b83d38e987ef2e57558695040a25219c39eaa0e31a0ead16a5c925c1c",
                verification_gas_limit: "100000",
                paymaster_and_data : "0x"
            }

 }
const tryPayResponse = await client.tryPayUserOperationV1(authResponse.token, request)
```
