import {
	createPublicClient,
	formatEther,
	http,
	parseAbi,
	publicActions,
} from 'viem'
import { foundry } from 'viem/chains'
import dotenv from 'dotenv'

dotenv.config()

const main = async () => {
	const publicClient = createPublicClient({
		chain: foundry,
		transport: http(process.env.LOCAL_RPC_URL),
	}).extend(publicActions)

	console.log('Scanning ERC20 Transfer events...')

	const currentBlockNumber = await publicClient.getBlockNumber()
	console.log('Current block number:', currentBlockNumber)

	const fromBlock = 0n
	const toBlock = currentBlockNumber

	try {
		const logs = await publicClient.getLogs({
			fromBlock,
			toBlock,
			events: parseAbi([
				'event Approval(address indexed owner, address indexed spender, uint256 value)',
				'event Transfer(address indexed from, address indexed to, uint256 value)',
			]),
		})
		console.log(
			`\n在区块 ${fromBlock} 到 ${toBlock} 之间找到 ${logs.length} 个事件`,
		)

		for (const log of logs) {
			console.log('\n事件详情:')
			console.log(`事件类型: ${log.eventName}`)
			console.log(`合约地址: ${log.address}`)
			console.log(`交易哈希: ${log.transactionHash}`)
			console.log(`区块号: ${log.blockNumber}`)

			if (log.eventName === 'Transfer' && log.args.value !== undefined) {
				console.log(`从: ${log.args.from}`)
				console.log(`到: ${log.args.to}`)
				console.log(`金额: ${formatEther(log.args.value)}`)
			} else if (log.eventName === 'Approval' && log.args.value !== undefined) {
				console.log(`所有者: ${log.args.owner}`)
				console.log(`授权给: ${log.args.spender}`)
				console.log(`授权金额: ${formatEther(log.args.value)}`)
			}
		}
	} catch (error) {
		console.error('Error fetching logs:', error)
	}
}

main().catch((error) => {
	console.error(error)
	process.exitCode = 1
})
