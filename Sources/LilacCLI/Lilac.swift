import ArgumentParser
import Foundation
import LilacCore

let log = LilacLogger(label: "lilac-cli")

@main
struct Lilac: AsyncParsableCommand {

    struct GlobalArguments: ParsableArguments {
        @Flag(help: "Enable verbose output.")
        var verbose = false
    }

    static let configuration = CommandConfiguration(
        commandName: "lilac",
        abstract: "Lilac — Make anywhere feel like yours. Just let it unfold.",
        version: lilac.version.versionString,
        subcommands: [
            InitCommand.self,

            AddCommand.self,
            ApplyCommand.self,
            ChangeDirectoryCommand.self,
            DiffCommand.self,
            EditCommand.self,
            ForgotCommand.self,
            StatusCommand.self,

            SelfCommand.self,
        ],
    )

    @OptionGroup()
    var globalArgs: GlobalArguments

    func validate() throws {
        if globalArgs.verbose {
            log.addHandler(
                StreamHandler(
                    formatter: ColourFormatter(
                        template: "[{timestamp}] [{level}] {name}: {message}")
                )
            )
        }
    }

    public static func main(_ arguments: [String]?) async {
        let filename = "lilac.log"

        let formatter = Formatter(
            template: "{timestamp},{level},{name},{run_id},{command},{event},{message}",
            defaults: [
                "run_id": .string(UUID().uuidString.prefix(8).uppercased()),
                "event": .string("-"),
            ]
        )

        log.addHandler(
            FileHandler(
                filename: filename,
                formatter: formatter
            )
        )

        do {
            var command = try parseAsRoot(arguments)

            let commandType = type(of: command)
            let commandName =
                commandType.configuration.commandName ?? String(describing: commandType)

            formatter[metadataKey: "command"] = .string(commandName)

            try log.debug("starting command", metadata: ["event": .string("start")])

            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }

            // log.debug("debug message")
            // log.info("info message")
            // log.error("error message")
            // log.warn("warn message")
            // log.critical("critical message")

            try log.debug("finished command", metadata: ["event": .string("end")])

        } catch {
            let arguments = arguments ?? Array(CommandLine.arguments.dropFirst())

            if error is LilacError {
                log.error("command failed with error: \(error) with arguments: \(arguments)")
            } else {
                log.error(
                    "command failed with unexpected error: \(error) with arguments: \(arguments)")
            }

            exit(withError: error)
        }

    }

    public static func main() async {
        await self.main(nil)
    }

}
