import { args, BaseCommand } from '@adonisjs/core/build/standalone'

export default class MakeRepo extends BaseCommand {
  /**
   * Command name is used to run the command
   */
  public static commandName = 'make:repo'

  /**
   * Command description is displayed in the "help" output
   */
  public static description = ''

  public static settings = {
    /**
     * Set the following value to true, if you want to load the application
     * before running the command. Don't forget to call `node ace generate:manifest` 
     * afterwards.
     */
    loadApp: false,

    /**
     * Set the following value to true, if you want this command to keep running until
     * you manually decide to exit the process. Don't forget to call 
     * `node ace generate:manifest` afterwards.
     */
    stayAlive: false,
  }

  @args.string({ description: 'Name of the repository' })
  public name: string

  public async run() {
    const stub = `\nexport class {{filename}} {\n\n}`

    const name = this.name

    this.generator
      .addFile(name, {
        pattern: 'pascalcase',
        suffix: 'Repo',
      })
      .appRoot(this.application.appRoot)
      .destinationDir('app/Repositories')
      .useMustache()
      .stub(stub, { raw: true })
      .apply({ resourceful: true })

    await this.generator.run()
  }
}
