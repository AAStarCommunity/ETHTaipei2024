import {
    BaseAccountAPI,
    BaseApiParams,
} from '@account-abstraction/sdk/dist/src/BaseAccountAPI';
import {BigNumber, BigNumberish} from "ethers";
export default class  ac extends BaseAccountAPI {
    encodeExecute(target: string, value: BigNumberish, data: string): Promise<string> {
        return Promise.resolve("");
    }

    getAccountInitCode(): Promise<string> {
        return Promise.resolve("");
    }

    getNonce(): Promise<BigNumber> {
        // @ts-ignore
        return Promise.resolve(undefined);
    }

    signUserOpHash(userOpHash: string): Promise<string> {
        return Promise.resolve("");
    }
    // constructor(params: AccountApiParamsType<any, any>);
    // serialize: () => Promise<object>;
    // createUnsignedUserOpWithContext(info: TransactionDetailsForUserOp, preTransactionConfirmationContext?: any): Promise<UserOperationStruct>;
    // signMessage: (request?: MessageSigningRequest, context?: any) => Promise<string>;
    // signUserOpWithContext(userOp: UserOperationStruct, postTransactionConfirmationContext?: any): Promise<UserOperationStruct>;
}