import {ethers, BigNumber, BigNumberish} from 'ethers'
import {
    EntryPoint, EntryPoint__factory,
    UserOperationStruct
} from '@account-abstraction/contracts'
import {BaseAccountAPI} from "@account-abstraction/sdk/dist/src/BaseAccountAPI";
import {SimpleAccountAPI} from "@account-abstraction/sdk/src/SimpleAccountAPI";
import {Path} from "./path";

export function buildCallData() {
    return "callDataBuider";
}

export function buildUserOp() {
    // let  api = new SimpleAccountAPI({
    //     index: 0,
    //     owner: new ethers.Wallet(""),
    //     factoryAddress: ""
    // });

    return "callDataBuider2";
}

export function generateUrl(prefix: string, path: Path, params?: Map<string, string>):string {
    let url = new URL(path, prefix)
    if(params != undefined){
        for (let [key, value] of params) {
            if (value != undefined) {
                url.searchParams.set(key, value)
            }
        }
    }
    return url.toString()
}

