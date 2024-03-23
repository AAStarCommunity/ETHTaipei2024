export class PaymasterError extends Error {
  readonly name = 'PaymasterError'
  readonly statusCode: number

  static async from(response: Response) {
    const payload = (await response.json()) as { message: string }
    return new PaymasterError(payload.message, response.status)
  }

  constructor(message: string, statusCode: number) {
    super(message)
    this.statusCode = statusCode
  }

}
